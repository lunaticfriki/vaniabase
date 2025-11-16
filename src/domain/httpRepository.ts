export abstract class HttpRepository<T> {
  abstract getItems(endpoint: string, options?: RequestInit): Promise<T[]>;
  abstract getItem(endpoint: string, options?: RequestInit): Promise<T>;
  abstract postItem(
    endpoint: string,
    data: T,
    options?: RequestInit
  ): Promise<void>;
  abstract putItem(
    endpoint: string,
    data: T,
    options?: RequestInit
  ): Promise<T>;
  abstract deleteItem(endpoint: string, options?: RequestInit): void;
}
