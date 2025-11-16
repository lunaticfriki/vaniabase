use actix_cors::Cors;
use actix_web::{
    delete, get, post, put, web, App, HttpResponse, HttpServer, Responder, Result,
};
use serde::{Deserialize, Serialize};
use std::io::{self, Write};
use std::sync::Mutex;
use std::{fs, process};
use uuid::Uuid;

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

struct AppState {
    items: Mutex<Vec<Item>>,
}

fn load_items_from_file() -> Vec<Item> {
    let data_path = concat!(env!("CARGO_MANIFEST_DIR"), "/data/items.seed.json");
    let contents = fs::read_to_string(data_path)
        .expect("Failed to read items.seed.json");
    serde_json::from_str(&contents).expect("Failed to parse JSON")
}

#[get("/api/items")]
async fn get_items(data: web::Data<AppState>) -> Result<impl Responder> {
    let items = data.items.lock().unwrap();
    Ok(web::Json(items.clone()))
}

#[get("/api/items/{id}")]
async fn get_item(path: web::Path<String>, data: web::Data<AppState>) -> Result<impl Responder> {
    let id = path.into_inner();
    let items = data.items.lock().unwrap();
    
    match items.iter().find(|item| item.id == id) {
        Some(item) => Ok(HttpResponse::Ok().json(item)),
        None => Ok(HttpResponse::NotFound().json(serde_json::json!({
            "error": "Item not found"
        }))),
    }
}

#[post("/api/items")]
async fn create_item(
    item: web::Json<Item>,
    data: web::Data<AppState>,
) -> Result<impl Responder> {
    let mut new_item = item.into_inner();
    new_item.id = Uuid::new_v4().to_string();
    
    let mut items = data.items.lock().unwrap();
    items.push(new_item.clone());
    
    Ok(HttpResponse::Created().json(new_item))
}

#[put("/api/items/{id}")]
async fn update_item(
    path: web::Path<String>,
    item: web::Json<Item>,
    data: web::Data<AppState>,
) -> Result<impl Responder> {
    let id = path.into_inner();
    let mut items = data.items.lock().unwrap();
    
    match items.iter_mut().find(|i| i.id == id) {
        Some(existing_item) => {
            let updated = item.into_inner();
            existing_item.name = updated.name;
            existing_item.author = updated.author;
            existing_item.description = updated.description;
            existing_item.image_url = updated.image_url;
            existing_item.topic = updated.topic;
            existing_item.tags = updated.tags;
            existing_item.owner = updated.owner;
            existing_item.completed = updated.completed;
            existing_item.year = updated.year;
            existing_item.language = updated.language;
            existing_item.format = updated.format;
            existing_item.category = updated.category;
            
            Ok(HttpResponse::Ok().json(existing_item.clone()))
        }
        None => Ok(HttpResponse::NotFound().json(serde_json::json!({
            "error": "Item not found"
        }))),
    }
}

#[delete("/api/items/{id}")]
async fn delete_item(path: web::Path<String>, data: web::Data<AppState>) -> Result<impl Responder> {
    let id = path.into_inner();
    let mut items = data.items.lock().unwrap();
    
    let initial_len = items.len();
    items.retain(|item| item.id != id);
    
    if items.len() < initial_len {
        Ok(HttpResponse::NoContent().finish())
    } else {
        Ok(HttpResponse::NotFound().json(serde_json::json!({
            "error": "Item not found"
        })))
    }
}

#[get("/health")]
async fn health_check(data: web::Data<AppState>) -> Result<impl Responder> {
    let items = data.items.lock().unwrap();
    Ok(web::Json(serde_json::json!({
        "status": "ok",
        "items": items.len()
    })))
}

fn check_missing_covers(items: &[Item]) -> bool {
    items.iter().any(|item| {
        !item.image_url.contains("covers.openlibrary.org")
            && !item.image_url.contains("logo.ts")
    })
}

fn list_seed_elements(items: &[Item]) {
    println!("\n📚 Current Seed Data:\n");
    println!("{}", "═".repeat(80));

    for (index, item) in items.iter().enumerate() {
        let cover_status = if item.image_url.contains("covers.openlibrary.org") {
            "✓"
        } else if item.image_url.contains("logo.ts") {
            "📘"
        } else {
            "✗"
        };

        println!("\n{}. {}", index + 1, item.name);
        println!("   Author: {}", item.author);
        println!("   Category: {}", item.category);
        println!("   Year: {} | Topic: {}", item.year, item.topic);
        println!("   Format: {} | Language: {}", item.format, item.language);
        println!("   Cover: {} {}", cover_status, item.image_url);
        println!("   Completed: {}", if item.completed { "✓" } else { "✗" });
        println!("   Tags: {}", item.tags.join(", "));
    }

    let open_library_count = items
        .iter()
        .filter(|i| i.image_url.contains("covers.openlibrary.org"))
        .count();

    println!("\n{}", "═".repeat(80));
    println!(
        "\nTotal: {} items | {} with Open Library covers\n",
        items.len(),
        open_library_count
    );
}

fn show_menu(items: &[Item]) -> io::Result<String> {
    let has_missing_covers = check_missing_covers(items);
    let cover_status = if has_missing_covers {
        "⚠️  Some covers missing"
    } else {
        "✓ All covers OK"
    };

    println!("\n╔════════════════════════════════════════╗");
    println!("║     Mock API Server - Main Menu        ║");
    println!("╚════════════════════════════════════════╝\n");
    println!("Status: {}\n", cover_status);
    println!("1. 🔄 Update covers from API");
    println!("2. 🔧 Fix missing covers");
    println!("3. 🚀 Start the server");
    println!("4. 📋 List seed elements");
    println!("5. 🚪 Exit\n");

    print!("Select an option (1-5): ");
    io::stdout().flush()?;

    let mut input = String::new();
    io::stdin().read_line(&mut input)?;
    Ok(input.trim().to_string())
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));

    println!("🎬 Starting Mock API Server (Rust version)...\n");

    let items = load_items_from_file();
    let app_state = web::Data::new(AppState {
        items: Mutex::new(items.clone()),
    });

    // Interactive menu loop
    let mut continue_menu = true;
    while continue_menu {
        let items = app_state.items.lock().unwrap().clone();
        match show_menu(&items) {
            Ok(choice) => match choice.as_str() {
                "1" => {
                    println!("\n🔄 Running update-covers...\n");
                    let status = std::process::Command::new("cargo")
                        .arg("run")
                        .arg("--bin")
                        .arg("update-covers")
                        .status();
                    
                    match status {
                        Ok(exit_status) if exit_status.success() => {
                            println!("\n✓ Cover update completed\n");
                            // Reload items
                            let new_items = load_items_from_file();
                            let mut items_lock = app_state.items.lock().unwrap();
                            items_lock.clear();
                            items_lock.extend(new_items);
                        }
                        _ => {
                            println!("\n✗ Cover update failed\n");
                        }
                    }
                    println!("Press Enter to continue...");
                    let mut _input = String::new();
                    io::stdin().read_line(&mut _input).ok();
                }
                "2" => {
                    println!("\n🔧 Running fix-missing-covers...\n");
                    let status = std::process::Command::new("cargo")
                        .arg("run")
                        .arg("--bin")
                        .arg("fix-missing-covers")
                        .status();
                    
                    match status {
                        Ok(exit_status) if exit_status.success() => {
                            println!("\n✓ Missing covers fix completed\n");
                            // Reload items
                            let new_items = load_items_from_file();
                            let mut items_lock = app_state.items.lock().unwrap();
                            items_lock.clear();
                            items_lock.extend(new_items);
                        }
                        _ => {
                            println!("\n✗ Missing covers fix failed\n");
                        }
                    }
                    println!("Press Enter to continue...");
                    let mut _input = String::new();
                    io::stdin().read_line(&mut _input).ok();
                }
                "3" => {
                    continue_menu = false;
                }
                "4" => {
                    list_seed_elements(&items);
                    println!("Press Enter to continue...");
                    let mut _input = String::new();
                    io::stdin().read_line(&mut _input).ok();
                }
                "5" => {
                    println!("\n👋 Goodbye!\n");
                    process::exit(0);
                }
                _ => {
                    println!("\n❌ Invalid option. Please select 1-5.\n");
                }
            },
            Err(e) => {
                eprintln!("Error reading input: {}", e);
                process::exit(1);
            }
        }
    }

    // Start the server
    let port = 3001;
    println!("\n🚀 Mock API server running at http://localhost:{}", port);
    println!("📦 Loaded {} items from seed", app_state.items.lock().unwrap().len());
    println!("\nAvailable endpoints:");
    println!("  GET    /api/items       - Get all items");
    println!("  GET    /api/items/:id   - Get item by id");
    println!("  POST   /api/items       - Create new item");
    println!("  PUT    /api/items/:id   - Update item");
    println!("  DELETE /api/items/:id   - Delete item");
    println!("  GET    /health          - Health check\n");

    HttpServer::new(move || {
        let cors = Cors::permissive();
        
        App::new()
            .wrap(cors)
            .app_data(app_state.clone())
            .service(get_items)
            .service(get_item)
            .service(create_item)
            .service(update_item)
            .service(delete_item)
            .service(health_check)
    })
    .bind(("127.0.0.1", port))?
    .run()
    .await
}

#[cfg(test)]
mod tests {
    use super::*;
    use actix_web::{test, App};

    fn create_test_items() -> Vec<Item> {
        vec![
            Item {
                id: "test-id-1".to_string(),
                name: "Test Book 1".to_string(),
                author: "Test Author".to_string(),
                description: "A test book".to_string(),
                image_url: "https://example.com/cover1.jpg".to_string(),
                topic: "Testing".to_string(),
                tags: vec!["test".to_string(), "book".to_string()],
                owner: "test-user".to_string(),
                completed: false,
                year: "2025".to_string(),
                language: "English".to_string(),
                format: "Book".to_string(),
                category: "books".to_string(),
            },
            Item {
                id: "test-id-2".to_string(),
                name: "Test Game 1".to_string(),
                author: "Test Studio".to_string(),
                description: "A test game".to_string(),
                image_url: "https://example.com/cover2.jpg".to_string(),
                topic: "Gaming".to_string(),
                tags: vec!["test".to_string(), "game".to_string()],
                owner: "test-user".to_string(),
                completed: true,
                year: "2024".to_string(),
                language: "English".to_string(),
                format: "Digital".to_string(),
                category: "videogames".to_string(),
            },
        ]
    }

    #[actix_web::test]
    async fn test_get_all_items() {
        let items = create_test_items();
        let app_state = web::Data::new(AppState {
            items: Mutex::new(items.clone()),
        });

        let app = test::init_service(
            App::new()
                .app_data(app_state.clone())
                .service(get_items)
        )
        .await;

        let req = test::TestRequest::get()
            .uri("/api/items")
            .to_request();

        let resp = test::call_service(&app, req).await;
        assert!(resp.status().is_success());

        let body: Vec<Item> = test::read_body_json(resp).await;
        assert_eq!(body.len(), 2);
        assert_eq!(body[0].name, "Test Book 1");
        assert_eq!(body[1].name, "Test Game 1");
    }

    #[actix_web::test]
    async fn test_get_item_by_id() {
        let items = create_test_items();
        let app_state = web::Data::new(AppState {
            items: Mutex::new(items.clone()),
        });

        let app = test::init_service(
            App::new()
                .app_data(app_state.clone())
                .service(get_item)
        )
        .await;

        let req = test::TestRequest::get()
            .uri("/api/items/test-id-1")
            .to_request();

        let resp = test::call_service(&app, req).await;
        assert!(resp.status().is_success());

        let body: Item = test::read_body_json(resp).await;
        assert_eq!(body.id, "test-id-1");
        assert_eq!(body.name, "Test Book 1");
        assert_eq!(body.author, "Test Author");
    }

    #[actix_web::test]
    async fn test_get_item_not_found() {
        let items = create_test_items();
        let app_state = web::Data::new(AppState {
            items: Mutex::new(items),
        });

        let app = test::init_service(
            App::new()
                .app_data(app_state.clone())
                .service(get_item)
        )
        .await;

        let req = test::TestRequest::get()
            .uri("/api/items/non-existent-id")
            .to_request();

        let resp = test::call_service(&app, req).await;
        assert_eq!(resp.status().as_u16(), 404);
    }

    #[actix_web::test]
    async fn test_create_item() {
        let items = create_test_items();
        let app_state = web::Data::new(AppState {
            items: Mutex::new(items),
        });

        let app = test::init_service(
            App::new()
                .app_data(app_state.clone())
                .service(create_item)
        )
        .await;

        let new_item = Item {
            id: "".to_string(), // Will be generated
            name: "New Test Book".to_string(),
            author: "New Author".to_string(),
            description: "A new test book".to_string(),
            image_url: "https://example.com/new.jpg".to_string(),
            topic: "New Topic".to_string(),
            tags: vec!["new".to_string()],
            owner: "new-user".to_string(),
            completed: false,
            year: "2025".to_string(),
            language: "English".to_string(),
            format: "Book".to_string(),
            category: "books".to_string(),
        };

        let req = test::TestRequest::post()
            .uri("/api/items")
            .set_json(&new_item)
            .to_request();

        let resp = test::call_service(&app, req).await;
        assert_eq!(resp.status().as_u16(), 201);

        let body: Item = test::read_body_json(resp).await;
        assert_eq!(body.name, "New Test Book");
        assert!(!body.id.is_empty()); // UUID should be generated

        // Verify item was added to state
        let items = app_state.items.lock().unwrap();
        assert_eq!(items.len(), 3);
    }

    #[actix_web::test]
    async fn test_update_item() {
        let items = create_test_items();
        let app_state = web::Data::new(AppState {
            items: Mutex::new(items),
        });

        let app = test::init_service(
            App::new()
                .app_data(app_state.clone())
                .service(update_item)
        )
        .await;

        let updated_item = Item {
            id: "test-id-1".to_string(),
            name: "Updated Book".to_string(),
            author: "Updated Author".to_string(),
            description: "Updated description".to_string(),
            image_url: "https://example.com/updated.jpg".to_string(),
            topic: "Updated Topic".to_string(),
            tags: vec!["updated".to_string()],
            owner: "updated-user".to_string(),
            completed: true,
            year: "2026".to_string(),
            language: "Spanish".to_string(),
            format: "Ebook".to_string(),
            category: "books".to_string(),
        };

        let req = test::TestRequest::put()
            .uri("/api/items/test-id-1")
            .set_json(&updated_item)
            .to_request();

        let resp = test::call_service(&app, req).await;
        assert!(resp.status().is_success());

        let body: Item = test::read_body_json(resp).await;
        assert_eq!(body.name, "Updated Book");
        assert_eq!(body.completed, true);
    }

    #[actix_web::test]
    async fn test_update_item_not_found() {
        let items = create_test_items();
        let app_state = web::Data::new(AppState {
            items: Mutex::new(items),
        });

        let app = test::init_service(
            App::new()
                .app_data(app_state.clone())
                .service(update_item)
        )
        .await;

        let updated_item = Item {
            id: "non-existent".to_string(),
            name: "Should Fail".to_string(),
            author: "Test".to_string(),
            description: "Test".to_string(),
            image_url: "Test".to_string(),
            topic: "Test".to_string(),
            tags: vec![],
            owner: "test".to_string(),
            completed: false,
            year: "2025".to_string(),
            language: "English".to_string(),
            format: "Book".to_string(),
            category: "books".to_string(),
        };

        let req = test::TestRequest::put()
            .uri("/api/items/non-existent")
            .set_json(&updated_item)
            .to_request();

        let resp = test::call_service(&app, req).await;
        assert_eq!(resp.status().as_u16(), 404);
    }

    #[actix_web::test]
    async fn test_delete_item() {
        let items = create_test_items();
        let app_state = web::Data::new(AppState {
            items: Mutex::new(items),
        });

        let app = test::init_service(
            App::new()
                .app_data(app_state.clone())
                .service(delete_item)
        )
        .await;

        let req = test::TestRequest::delete()
            .uri("/api/items/test-id-1")
            .to_request();

        let resp = test::call_service(&app, req).await;
        assert_eq!(resp.status().as_u16(), 204);

        // Verify item was deleted
        let items = app_state.items.lock().unwrap();
        assert_eq!(items.len(), 1);
        assert_eq!(items[0].id, "test-id-2");
    }

    #[actix_web::test]
    async fn test_delete_item_not_found() {
        let items = create_test_items();
        let app_state = web::Data::new(AppState {
            items: Mutex::new(items),
        });

        let app = test::init_service(
            App::new()
                .app_data(app_state.clone())
                .service(delete_item)
        )
        .await;

        let req = test::TestRequest::delete()
            .uri("/api/items/non-existent-id")
            .to_request();

        let resp = test::call_service(&app, req).await;
        assert_eq!(resp.status().as_u16(), 404);
    }

    #[actix_web::test]
    async fn test_health_check() {
        let items = create_test_items();
        let app_state = web::Data::new(AppState {
            items: Mutex::new(items),
        });

        let app = test::init_service(
            App::new()
                .app_data(app_state.clone())
                .service(health_check)
        )
        .await;

        let req = test::TestRequest::get()
            .uri("/health")
            .to_request();

        let resp = test::call_service(&app, req).await;
        assert!(resp.status().is_success());

        let body: serde_json::Value = test::read_body_json(resp).await;
        assert_eq!(body["status"], "ok");
        assert_eq!(body["items"], 2);
    }

    #[tokio::test]
    async fn test_check_missing_covers() {
        let items = vec![
            Item {
                id: "1".to_string(),
                name: "Test".to_string(),
                author: "Test".to_string(),
                description: "Test".to_string(),
                image_url: "https://covers.openlibrary.org/test.jpg".to_string(),
                topic: "Test".to_string(),
                tags: vec![],
                owner: "test".to_string(),
                completed: false,
                year: "2025".to_string(),
                language: "English".to_string(),
                format: "Book".to_string(),
                category: "books".to_string(),
            },
            Item {
                id: "2".to_string(),
                name: "Test 2".to_string(),
                author: "Test".to_string(),
                description: "Test".to_string(),
                image_url: "https://example.com/test.jpg".to_string(),
                topic: "Test".to_string(),
                tags: vec![],
                owner: "test".to_string(),
                completed: false,
                year: "2025".to_string(),
                language: "English".to_string(),
                format: "Book".to_string(),
                category: "books".to_string(),
            },
        ];

        // First item has openlibrary cover (good), second doesn't (missing)
        assert!(check_missing_covers(&items));

        // All items with openlibrary covers
        let items_ok = vec![
            Item {
                id: "1".to_string(),
                name: "Test".to_string(),
                author: "Test".to_string(),
                description: "Test".to_string(),
                image_url: "https://covers.openlibrary.org/test.jpg".to_string(),
                topic: "Test".to_string(),
                tags: vec![],
                owner: "test".to_string(),
                completed: false,
                year: "2025".to_string(),
                language: "English".to_string(),
                format: "Book".to_string(),
                category: "books".to_string(),
            },
        ];

        assert!(!check_missing_covers(&items_ok));
    }
}
