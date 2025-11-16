import type { FetchService } from '../domain/fetchService';

export class FetchServiceImpl implements FetchService {
  async get(url: string, options?: RequestInit): Promise<Response> {
    return fetch(url, { method: 'GET', ...options });
  }
  async post(
    url: string,
    body: BodyInit | null,
    options?: RequestInit
  ): Promise<Response> {
    return fetch(url, { method: 'POST', body, ...options });
  }
  async put(
    url: string,
    body: BodyInit | null,
    options?: RequestInit
  ): Promise<Response> {
    return fetch(url, { method: 'PUT', body, ...options });
  }
  async delete(url: string, options?: RequestInit): Promise<Response> {
    return fetch(url, { method: 'DELETE', ...options });
  }
}
