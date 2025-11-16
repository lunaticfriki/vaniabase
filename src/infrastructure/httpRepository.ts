import type { HttpRepository } from '../domain/httpRepository';
import type { Item } from '../domain/item';

export class ItemsHttpRepository implements HttpRepository<Item> {
  private readonly baseUrl: string;
  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }

  async getItems(endpoint: string, options?: RequestInit): Promise<Item[]> {
    const response = await fetch(`${this.baseUrl}${endpoint}`, {
      method: 'GET',
      ...options,
    });
    if (!response.ok) {
      throw new Error(`Failed to fetch items: ${response.statusText}`);
    }
    return response.json();
  }

  async getItem(endpoint: string, options?: RequestInit): Promise<Item> {
    const response = await fetch(`${this.baseUrl}${endpoint}`, {
      method: 'GET',
      ...options,
    });
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
    const response = await fetch(`${this.baseUrl}${endpoint}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(options?.headers || {}),
      },
      body: JSON.stringify(data),
      ...options,
    });
    if (!response.ok) {
      throw new Error(`Failed to post item: ${response.statusText}`);
    }
  }

  async putItem(
    endpoint: string,
    data: Item,
    options?: RequestInit
  ): Promise<Item> {
    const response = await fetch(`${this.baseUrl}${endpoint}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        ...(options?.headers || {}),
      },
      body: JSON.stringify(data),
      ...options,
    });
    if (!response.ok) {
      throw new Error(`Failed to put item: ${response.statusText}`);
    }
    return response.json();
  }

  async deleteItem(endpoint: string, options?: RequestInit): Promise<void> {
    const response = await fetch(`${this.baseUrl}${endpoint}`, {
      method: 'DELETE',
      ...options,
    });
    if (!response.ok) {
      throw new Error(`Failed to delete item: ${response.statusText}`);
    }
  }
}
