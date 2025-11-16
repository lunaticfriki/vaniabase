import type { HttpRepository } from '../domain/httpRepository';
import type { Item } from '../domain/item';
import type { FetchService } from '../domain/fetchService';

export class ItemsHttpRepository implements HttpRepository<Item> {
  private readonly baseUrl: string;
  private readonly fetchService: FetchService;

  constructor(baseUrl: string, fetchService: FetchService) {
    this.baseUrl = baseUrl;
    this.fetchService = fetchService;
  }

  async getItems(endpoint: string, options?: RequestInit): Promise<Item[]> {
    const response = await this.fetchService.get(
      `${this.baseUrl}${endpoint}`,
      options
    );
    if (!response.ok) {
      throw new Error(`Failed to fetch items: ${response.statusText}`);
    }
    return response.json();
  }

  async getItem(endpoint: string, options?: RequestInit): Promise<Item> {
    const response = await this.fetchService.get(
      `${this.baseUrl}${endpoint}`,
      options
    );
    if (!response.ok) {
      throw new Error(`Failed to fetch item: ${response.statusText}`);
    }
    return response.json();
  }

  async postItem(
    endpoint: string,
    data: Item,
    options?: RequestInit
  ): Promise<void> {
    const response = await this.fetchService.post(
      `${this.baseUrl}${endpoint}`,
      JSON.stringify(data),
      {
        ...options,
        headers: {
          'Content-Type': 'application/json',
          ...(options?.headers || {}),
        },
      }
    );
    if (!response.ok) {
      throw new Error(`Failed to post item: ${response.statusText}`);
    }
  }

  async putItem(
    endpoint: string,
    data: Item,
    options?: RequestInit
  ): Promise<Item> {
    const response = await this.fetchService.put(
      `${this.baseUrl}${endpoint}`,
      JSON.stringify(data),
      {
        ...options,
        headers: {
          'Content-Type': 'application/json',
          ...(options?.headers || {}),
        },
      }
    );
    if (!response.ok) {
      throw new Error(`Failed to put item: ${response.statusText}`);
    }
    return response.json();
  }

  async deleteItem(endpoint: string, options?: RequestInit): Promise<void> {
    const response = await this.fetchService.delete(
      `${this.baseUrl}${endpoint}`,
      options
    );
    if (!response.ok) {
      throw new Error(`Failed to delete item: ${response.statusText}`);
    }
  }
}
