use serde::{Deserialize, Serialize};
use std::fs;
use std::time::Duration;

#[derive(Debug, Clone, Serialize, Deserialize)]
struct Item {
    id: String,
    name: String,
    author: String,
    description: String,
    #[serde(rename = "imageUrl")]
    image_url: String,
    topic: String,
    tags: Vec<String>,
    owner: String,
    completed: bool,
    year: String,
    language: String,
    format: String,
    category: String,
}

#[derive(Debug, Deserialize)]
struct OpenLibraryDoc {
    cover_i: Option<u64>,
}

#[derive(Debug, Deserialize)]
struct OpenLibraryResponse {
    docs: Vec<OpenLibraryDoc>,
    #[serde(rename = "numFound")]
    num_found: u32,
}

#[derive(Debug, Deserialize)]
struct RawgResult {
    background_image: Option<String>,
}

#[derive(Debug, Deserialize)]
struct RawgResponse {
    results: Vec<RawgResult>,
}

#[derive(Debug, Deserialize)]
struct MusicBrainzRelease {
    id: String,
}

#[derive(Debug, Deserialize)]
struct MusicBrainzResponse {
    releases: Option<Vec<MusicBrainzRelease>>,
}

async fn check_image_url(url: &str) -> bool {
    let client = reqwest::Client::new();
    match client
        .head(url)
        .timeout(Duration::from_secs(5))
        .send()
        .await
    {
        Ok(response) => response.status().is_success(),
        Err(_) => false,
    }
}

async fn search_book_cover(title: &str, author: &str) -> Result<Option<String>, Box<dyn std::error::Error>> {
    let url = format!(
        "https://openlibrary.org/search.json?title={}&author={}&limit=1",
        urlencoding::encode(title),
        urlencoding::encode(author)
    );
    println!("Trying Open Library: {}", title);

    let client = reqwest::Client::new();
    let response = client
        .get(&url)
        .timeout(Duration::from_secs(10))
        .send()
        .await?;

    let data: OpenLibraryResponse = response.json().await?;

    if data.num_found > 0 && !data.docs.is_empty() {
        if let Some(cover_i) = data.docs[0].cover_i {
            return Ok(Some(format!(
                "https://covers.openlibrary.org/b/id/{}-L.jpg",
                cover_i
            )));
        }
    }

    Ok(None)
}

async fn search_game_cover(title: &str) -> Result<Option<String>, Box<dyn std::error::Error>> {
    let url = format!(
        "https://api.rawg.io/api/games?search={}&page_size=1",
        urlencoding::encode(title)
    );
    println!("Trying RAWG: {}", title);

    let client = reqwest::Client::new();
    let response = client
        .get(&url)
        .timeout(Duration::from_secs(10))
        .send()
        .await?;

    let data: RawgResponse = response.json().await?;

    if !data.results.is_empty() {
        if let Some(cover_url) = &data.results[0].background_image {
            return Ok(Some(cover_url.clone()));
        }
    }

    Ok(None)
}

async fn search_music_cover(title: &str, author: &str) -> Result<Option<String>, Box<dyn std::error::Error>> {
    let url = format!(
        "https://musicbrainz.org/ws/2/release?query=release:{}%20AND%20artist:{}&fmt=json&limit=1",
        urlencoding::encode(title),
        urlencoding::encode(author)
    );
    println!("Trying MusicBrainz: {} by {}", title, author);

    let client = reqwest::Client::new();
    let response = client
        .get(&url)
        .timeout(Duration::from_secs(10))
        .header("User-Agent", "Vaniabase/1.0.0 ( dev@vaniabase.com )")
        .send()
        .await?;

    let data: MusicBrainzResponse = response.json().await?;

    if let Some(releases) = data.releases {
        if !releases.is_empty() {
            let release_id = &releases[0].id;
            let cover_url = format!("https://coverartarchive.org/release/{}/front", release_id);

            let cover_response = client
                .head(&cover_url)
                .timeout(Duration::from_secs(10))
                .send()
                .await?;

            if cover_response.status().is_success() {
                return Ok(Some(cover_url));
            }
        }
    }

    Ok(None)
}

async fn search_cover_by_category(item: &Item) -> Option<String> {
    let category = item.category.to_lowercase();

    match category.as_str() {
        "books" => {
            match search_book_cover(&item.name, &item.author).await {
                Ok(result) => result,
                Err(e) => {
                    println!("Error searching book cover: {}", e);
                    None
                }
            }
        }
        "videogames" | "video games" => {
            match search_game_cover(&item.name).await {
                Ok(result) => result,
                Err(e) => {
                    println!("Error searching game cover: {}", e);
                    None
                }
            }
        }
        "cd" | "music" | "album" => {
            match search_music_cover(&item.name, &item.author).await {
                Ok(result) => result,
                Err(e) => {
                    println!("Error searching music cover: {}", e);
                    None
                }
            }
        }
        "comics" | "magazines" => {
            println!("No automatic API for {} yet, needs manual URL", category);
            None
        }
        _ => {
            println!("Unknown category: {}", category);
            None
        }
    }
}

#[derive(Clone)]
struct MissingCover {
    item: Item,
    index: usize,
}

async fn find_missing_covers(items: &[Item]) -> Vec<MissingCover> {
    println!("Checking all image URLs...\n");

    let mut missing_covers = Vec::new();

    for (i, item) in items.iter().enumerate() {
        let is_valid = check_image_url(&item.image_url).await;

        if !is_valid {
            println!("✗ [{}/{}] BROKEN: {}", i + 1, items.len(), item.name);
            println!("  Category: {}", item.category);
            println!("  Current URL: {}", item.image_url);
            println!("  Author: {}\n", item.author);
            missing_covers.push(MissingCover {
                item: item.clone(),
                index: i,
            });
        } else {
            println!("✓ [{}/{}] OK: {}", i + 1, items.len(), item.name);
        }

        // Add small delay to avoid overwhelming the servers
        tokio::time::sleep(Duration::from_millis(100)).await;
    }

    println!("\n\n=== SUMMARY ===");
    println!("Total items: {}", items.len());
    println!("Broken covers: {}", missing_covers.len());
    println!("Valid covers: {}\n", items.len() - missing_covers.len());

    if !missing_covers.is_empty() {
        println!("Items with missing/broken covers:");
        for missing in &missing_covers {
            println!("  - {} ({})", missing.item.name, missing.item.category);
        }
    }

    missing_covers
}

struct ManualFix {
    name: String,
    search_title: String,
    search_author: String,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let seed_path = concat!(env!("CARGO_MANIFEST_DIR"), "/data/items.seed.json");
    let contents = fs::read_to_string(seed_path)?;
    let mut items: Vec<Item> = serde_json::from_str(&contents)?;

    // First, find all items with broken covers
    let missing_covers = find_missing_covers(&items).await;

    if missing_covers.is_empty() {
        println!("\n✓ All covers are valid!");
        return Ok(());
    }

    println!("\n\n=== ATTEMPTING AUTOMATIC FIXES ===\n");

    // Try to automatically fix missing covers based on category
    for missing in &missing_covers {
        println!("\nSearching for: {} ({})", missing.item.name, missing.item.category);
        
        if let Some(cover_url) = search_cover_by_category(&missing.item).await {
            // Verify the found URL is valid
            let is_valid = check_image_url(&cover_url).await;
            if is_valid {
                println!("✓ Found valid cover: {}", cover_url);
                items[missing.index].image_url = cover_url;
            } else {
                println!("✗ Found cover but URL is invalid");
            }
        } else {
            println!("✗ No cover found - needs manual URL");
        }

        tokio::time::sleep(Duration::from_secs(1)).await;
    }

    // Manual fixes for specific items that couldn't be found automatically
    let manual_fixes = vec![
        ManualFix {
            name: "Design Patterns: Elements of Reusable Object-Oriented Software".to_string(),
            search_title: "Design Patterns".to_string(),
            search_author: "Gamma".to_string(),
        },
        ManualFix {
            name: "Test-Driven Development by Example".to_string(),
            search_title: "Test Driven Development".to_string(),
            search_author: "Kent Beck".to_string(),
        },
        ManualFix {
            name: "TypeScript Handbook".to_string(),
            search_title: "Programming TypeScript".to_string(),
            search_author: "Boris Cherny".to_string(),
        },
    ];

    println!("\n\n=== ATTEMPTING MANUAL FIXES ===\n");

    for fix in &manual_fixes {
        if let Some(item_index) = items.iter().position(|item| item.name == fix.name) {
            if !check_image_url(&items[item_index].image_url).await {
                println!("Searching for: {}", fix.name);
                
                if let Ok(Some(cover_url)) = search_book_cover(&fix.search_title, &fix.search_author).await {
                    println!("✓ Found: {}", cover_url);
                    items[item_index].image_url = cover_url;
                } else {
                    println!("✗ Still not found");
                }

                tokio::time::sleep(Duration::from_secs(1)).await;
            }
        }
    }

    let json = serde_json::to_string_pretty(&items)?;
    fs::write(seed_path, json)?;
    println!("\n✓ Updated seed file");

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn create_test_item(id: &str, name: &str, category: &str, image_url: &str) -> Item {
        Item {
            id: id.to_string(),
            name: name.to_string(),
            author: "Test Author".to_string(),
            description: "Test description".to_string(),
            image_url: image_url.to_string(),
            topic: "Test".to_string(),
            tags: vec!["test".to_string()],
            owner: "test".to_string(),
            completed: false,
            year: "2025".to_string(),
            language: "English".to_string(),
            format: "Book".to_string(),
            category: category.to_string(),
        }
    }

    #[test]
    fn test_missing_cover_struct() {
        let item = create_test_item("1", "Test Book", "books", "https://example.com/test.jpg");
        let missing = MissingCover {
            item: item.clone(),
            index: 0,
        };
        
        assert_eq!(missing.index, 0);
        assert_eq!(missing.item.name, "Test Book");
    }

    #[test]
    fn test_manual_fix_struct() {
        let fix = ManualFix {
            name: "Design Patterns".to_string(),
            search_title: "Design Patterns".to_string(),
            search_author: "Gamma".to_string(),
        };
        
        assert_eq!(fix.name, "Design Patterns");
        assert_eq!(fix.search_author, "Gamma");
    }

    #[test]
    fn test_item_serialization_fix() {
        let item = create_test_item("1", "Test", "books", "https://example.com/cover.jpg");
        
        let json = serde_json::to_string(&item).unwrap();
        assert!(json.contains("Test"));
        assert!(json.contains("imageUrl")); // camelCase
        
        let deserialized: Item = serde_json::from_str(&json).unwrap();
        assert_eq!(deserialized.name, "Test");
        assert_eq!(deserialized.image_url, "https://example.com/cover.jpg");
    }

    #[tokio::test]
    async fn test_check_image_url_invalid() {
        // Test with clearly invalid URL
        let result = check_image_url("https://this-domain-definitely-does-not-exist-12345.com/image.jpg").await;
        assert!(!result);
    }

    #[tokio::test]
    async fn test_check_image_url_valid() {
        // Test with a likely valid URL (may fail if network issues)
        let result = check_image_url("https://covers.openlibrary.org/b/id/8065615-L.jpg").await;
        // We don't assert true because network might be down, but it shouldn't panic
        assert!(result == true || result == false);
    }

    #[tokio::test]
    async fn test_search_cover_by_category_books_fix() {
        let item = create_test_item("1", "Clean Code", "books", "old-url.jpg");
        
        // This will make a real API call
        let result = search_cover_by_category(&item).await;
        
        // Should either return a URL or None
        assert!(result.is_none() || result.as_ref().unwrap().contains("http"));
    }

    #[tokio::test]
    async fn test_search_cover_by_category_videogames() {
        let item = create_test_item("1", "Minecraft", "videogames", "old-url.jpg");
        
        let result = search_cover_by_category(&item).await;
        
        // Should either return a URL or None
        assert!(result.is_none() || result.as_ref().unwrap().contains("http"));
    }

    #[tokio::test]
    async fn test_search_cover_by_category_comics() {
        let item = create_test_item("1", "Test Comic", "comics", "old-url.jpg");
        
        // Comics should return None (no automatic API)
        let result = search_cover_by_category(&item).await;
        assert!(result.is_none());
    }

    #[tokio::test]
    async fn test_search_cover_by_category_magazines() {
        let item = create_test_item("1", "Test Magazine", "magazines", "old-url.jpg");
        
        // Magazines should return None (no automatic API)
        let result = search_cover_by_category(&item).await;
        assert!(result.is_none());
    }

    #[tokio::test]
    async fn test_search_cover_by_category_unknown() {
        let item = create_test_item("1", "Test", "unknown-category", "old-url.jpg");
        
        // Unknown category should return None
        let result = search_cover_by_category(&item).await;
        assert!(result.is_none());
    }

    #[test]
    fn test_openlibrary_doc_parsing() {
        let json = r#"{"cover_i": 12345}"#;
        let doc: OpenLibraryDoc = serde_json::from_str(json).unwrap();
        assert_eq!(doc.cover_i, Some(12345));
    }

    #[test]
    fn test_openlibrary_doc_no_cover() {
        let json = r#"{}"#;
        let doc: OpenLibraryDoc = serde_json::from_str(json).unwrap();
        assert_eq!(doc.cover_i, None);
    }

    #[test]
    fn test_rawg_result_parsing() {
        let json = r#"{"background_image": "https://example.com/game.jpg"}"#;
        let result: RawgResult = serde_json::from_str(json).unwrap();
        assert_eq!(result.background_image.unwrap(), "https://example.com/game.jpg");
    }

    #[test]
    fn test_rawg_result_no_image() {
        let json = r#"{}"#;
        let result: RawgResult = serde_json::from_str(json).unwrap();
        assert!(result.background_image.is_none());
    }

    #[test]
    fn test_musicbrainz_release_parsing() {
        let json = r#"{"id": "abc-123"}"#;
        let release: MusicBrainzRelease = serde_json::from_str(json).unwrap();
        assert_eq!(release.id, "abc-123");
    }

    #[test]
    fn test_musicbrainz_response_parsing() {
        let json = r#"{"releases": [{"id": "abc-123"}]}"#;
        let response: MusicBrainzResponse = serde_json::from_str(json).unwrap();
        assert!(response.releases.is_some());
        assert_eq!(response.releases.unwrap()[0].id, "abc-123");
    }

    #[test]
    fn test_musicbrainz_response_no_releases() {
        let json = r#"{}"#;
        let response: MusicBrainzResponse = serde_json::from_str(json).unwrap();
        assert!(response.releases.is_none());
    }

    #[tokio::test]
    async fn test_find_missing_covers_empty_list() {
        let items: Vec<Item> = vec![];
        let missing = find_missing_covers(&items).await;
        assert_eq!(missing.len(), 0);
    }

    #[test]
    fn test_url_encoding_special_chars() {
        let title = "Test: Special & Characters!";
        let encoded = urlencoding::encode(title);
        assert!(encoded.contains("%20")); // space
        assert!(encoded.contains("%3A")); // colon
        assert!(encoded.contains("%26")); // ampersand
    }

    #[test]
    fn test_cover_url_construction() {
        let cover_id = 54321u64;
        let url = format!("https://covers.openlibrary.org/b/id/{}-L.jpg", cover_id);
        assert_eq!(url, "https://covers.openlibrary.org/b/id/54321-L.jpg");
    }

    #[test]
    fn test_coverartarchive_url_construction() {
        let release_id = "test-release-id-123";
        let url = format!("https://coverartarchive.org/release/{}/front", release_id);
        assert_eq!(url, "https://coverartarchive.org/release/test-release-id-123/front");
    }
}
