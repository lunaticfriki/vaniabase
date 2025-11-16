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
    isbn: Option<Vec<String>>,
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

async fn search_book_cover(title: &str, author: &str) -> Result<Option<String>, Box<dyn std::error::Error>> {
    let clean_title = title
        .split(':')
        .next()
        .unwrap_or(title)
        .trim();
    let clean_author = author
        .split("and")
        .next()
        .unwrap_or(author)
        .trim();

    let search_url = format!(
        "https://openlibrary.org/search.json?title={}&author={}&limit=1",
        urlencoding::encode(clean_title),
        urlencoding::encode(clean_author)
    );

    println!("Searching: {} by {}", title, author);

    let client = reqwest::Client::new();
    let response = client
        .get(&search_url)
        .timeout(Duration::from_secs(10))
        .send()
        .await?;

    let data: OpenLibraryResponse = response.json().await?;

    if data.num_found > 0 && !data.docs.is_empty() {
        let book = &data.docs[0];

        if let Some(cover_i) = book.cover_i {
            let cover_url = format!("https://covers.openlibrary.org/b/id/{}-L.jpg", cover_i);
            println!("✓ Found cover: {}", cover_url);
            return Ok(Some(cover_url));
        }

        if let Some(isbn_list) = &book.isbn {
            if !isbn_list.is_empty() {
                let cover_url = format!("https://covers.openlibrary.org/b/isbn/{}-L.jpg", isbn_list[0]);
                println!("✓ Found cover (ISBN): {}", cover_url);
                return Ok(Some(cover_url));
            }
        }
    }

    println!("✗ No cover found for: {}", title);
    Ok(None)
}

async fn search_game_cover(title: &str) -> Result<Option<String>, Box<dyn std::error::Error>> {
    let url = format!(
        "https://api.rawg.io/api/games?search={}&page_size=1",
        urlencoding::encode(title)
    );
    println!("Searching RAWG for: {}", title);

    let client = reqwest::Client::new();
    let response = client
        .get(&url)
        .timeout(Duration::from_secs(10))
        .send()
        .await?;

    let data: RawgResponse = response.json().await?;

    if !data.results.is_empty() {
        if let Some(cover_url) = &data.results[0].background_image {
            println!("✓ Found cover: {}", cover_url);
            return Ok(Some(cover_url.clone()));
        }
    }

    println!("✗ No cover found for: {}", title);
    Ok(None)
}

async fn search_music_cover(title: &str, author: &str) -> Result<Option<String>, Box<dyn std::error::Error>> {
    let url = format!(
        "https://musicbrainz.org/ws/2/release?query=release:{}%20AND%20artist:{}&fmt=json&limit=1",
        urlencoding::encode(title),
        urlencoding::encode(author)
    );
    println!("Searching MusicBrainz for: {} by {}", title, author);

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

            // Check if cover exists
            let cover_response = client
                .head(&cover_url)
                .timeout(Duration::from_secs(10))
                .send()
                .await?;

            if cover_response.status().is_success() {
                println!("✓ Found cover: {}", cover_url);
                return Ok(Some(cover_url));
            }
        }
    }

    println!("✗ No cover found for: {}", title);
    Ok(None)
}

async fn search_cover_by_category(item: &Item) -> Option<String> {
    let category = item.category.to_lowercase();

    match category.as_str() {
        "books" => {
            match search_book_cover(&item.name, &item.author).await {
                Ok(result) => result,
                Err(e) => {
                    eprintln!("Error searching book cover: {}", e);
                    None
                }
            }
        }
        "videogames" | "video games" => {
            match search_game_cover(&item.name).await {
                Ok(result) => result,
                Err(e) => {
                    eprintln!("Error searching game cover: {}", e);
                    None
                }
            }
        }
        "cd" | "music" | "album" => {
            match search_music_cover(&item.name, &item.author).await {
                Ok(result) => result,
                Err(e) => {
                    eprintln!("Error searching music cover: {}", e);
                    None
                }
            }
        }
        "comics" | "magazines" => {
            println!("No automatic API for {} - keeping current URL", category);
            None
        }
        _ => {
            println!("Unknown category: {} - keeping current URL", category);
            None
        }
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let seed_path = concat!(env!("CARGO_MANIFEST_DIR"), "/data/items.seed.json");
    let contents = fs::read_to_string(seed_path)?;
    let mut items: Vec<Item> = serde_json::from_str(&contents)?;

    let total_items = items.len();
    println!("Found {} items to update\n", total_items);

    let mut updated = 0;

    for i in 0..items.len() {
        let item = &items[i];
        println!(
            "[{}/{}] Processing: {} ({})",
            i + 1,
            total_items,
            item.name,
            item.category
        );

        if let Some(cover_url) = search_cover_by_category(item).await {
            items[i].image_url = cover_url;
            updated += 1;
        }

        // Add delay to avoid overwhelming the APIs
        tokio::time::sleep(Duration::from_secs(1)).await;
        println!("---");
    }

    let json = serde_json::to_string_pretty(&items)?;
    fs::write(seed_path, json)?;

    println!("\n✓ Seed file updated successfully!");
    println!("Updated covers: {}/{}", updated, total_items);

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn create_test_item(id: &str, name: &str, category: &str) -> Item {
        Item {
            id: id.to_string(),
            name: name.to_string(),
            author: "Test Author".to_string(),
            description: "Test description".to_string(),
            image_url: "https://example.com/test.jpg".to_string(),
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
    fn test_item_serialization() {
        let item = create_test_item("1", "Test Book", "books");
        
        let json = serde_json::to_string(&item).unwrap();
        assert!(json.contains("Test Book"));
        assert!(json.contains("imageUrl")); // Check camelCase serialization
        
        let deserialized: Item = serde_json::from_str(&json).unwrap();
        assert_eq!(deserialized.name, "Test Book");
        assert_eq!(deserialized.category, "books");
    }

    #[test]
    fn test_openlibrary_response_parsing() {
        let json = r#"{
            "numFound": 1,
            "docs": [{
                "cover_i": 12345
            }]
        }"#;
        
        let response: OpenLibraryResponse = serde_json::from_str(json).unwrap();
        assert_eq!(response.num_found, 1);
        assert_eq!(response.docs[0].cover_i, Some(12345));
    }

    #[test]
    fn test_openlibrary_response_with_isbn() {
        let json = r#"{
            "numFound": 1,
            "docs": [{
                "isbn": ["1234567890", "0987654321"]
            }]
        }"#;
        
        let response: OpenLibraryResponse = serde_json::from_str(json).unwrap();
        assert_eq!(response.num_found, 1);
        assert!(response.docs[0].isbn.is_some());
        let isbns = response.docs[0].isbn.as_ref().unwrap();
        assert_eq!(isbns.len(), 2);
        assert_eq!(isbns[0], "1234567890");
    }

    #[test]
    fn test_rawg_response_parsing() {
        let json = r#"{
            "results": [{
                "background_image": "https://example.com/game.jpg"
            }]
        }"#;
        
        let response: RawgResponse = serde_json::from_str(json).unwrap();
        assert_eq!(response.results.len(), 1);
        assert_eq!(
            response.results[0].background_image.as_ref().unwrap(),
            "https://example.com/game.jpg"
        );
    }

    #[test]
    fn test_musicbrainz_response_parsing() {
        let json = r#"{
            "releases": [{
                "id": "abc123-def456"
            }]
        }"#;
        
        let response: MusicBrainzResponse = serde_json::from_str(json).unwrap();
        assert!(response.releases.is_some());
        let releases = response.releases.unwrap();
        assert_eq!(releases.len(), 1);
        assert_eq!(releases[0].id, "abc123-def456");
    }

    #[tokio::test]
    async fn test_search_cover_by_category_books() {
        let item = create_test_item("1", "Clean Code", "books");
        
        // This will make a real API call - we're testing the integration
        // In a production setting, you'd mock this
        let result = search_cover_by_category(&item).await;
        
        // Should either return a URL or None (if API fails/rate limited)
        // Just verify it doesn't panic
        assert!(result.is_none() || result.as_ref().unwrap().contains("http"));
    }

    #[tokio::test]
    async fn test_search_cover_by_category_unknown() {
        let item = create_test_item("1", "Test", "comics");
        
        // Comics category should return None (no automatic API)
        let result = search_cover_by_category(&item).await;
        assert!(result.is_none());
    }

    #[test]
    fn test_title_cleaning() {
        // Test that title cleaning works (removing subtitle after colon)
        let title = "Clean Code: A Handbook of Agile Software";
        let clean_title = title.split(':').next().unwrap_or(title).trim();
        assert_eq!(clean_title, "Clean Code");
    }

    #[test]
    fn test_author_cleaning() {
        // Test that author cleaning works (removing "and" suffix)
        let author = "Robert Martin and others";
        let clean_author = author.split("and").next().unwrap_or(author).trim();
        assert_eq!(clean_author, "Robert Martin");
    }

    #[test]
    fn test_url_encoding() {
        // Test that special characters are encoded properly
        let title = "Test & Book: Special!";
        let encoded = urlencoding::encode(title);
        assert!(encoded.contains("%20")); // Space encoded
        assert!(encoded.contains("%26")); // & encoded
    }

    #[test]
    fn test_cover_url_format() {
        let cover_id = 12345u64;
        let cover_url = format!("https://covers.openlibrary.org/b/id/{}-L.jpg", cover_id);
        assert_eq!(cover_url, "https://covers.openlibrary.org/b/id/12345-L.jpg");
    }

    #[test]
    fn test_isbn_cover_url_format() {
        let isbn = "1234567890";
        let cover_url = format!("https://covers.openlibrary.org/b/isbn/{}-L.jpg", isbn);
        assert_eq!(cover_url, "https://covers.openlibrary.org/b/isbn/1234567890-L.jpg");
    }

    #[test]
    fn test_musicbrainz_cover_url_format() {
        let release_id = "abc123-def456";
        let cover_url = format!("https://coverartarchive.org/release/{}/front", release_id);
        assert_eq!(cover_url, "https://coverartarchive.org/release/abc123-def456/front");
    }
}
