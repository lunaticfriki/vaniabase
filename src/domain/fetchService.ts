export abstract class FetchService {
  abstract get(url: string, options?: RequestInit): Promise<Response>;
  abstract post(
    url: string,
    body: BodyInit | null,
    options?: RequestInit
  ): Promise<Response>;
  abstract put(
    url: string,
    body: BodyInit | null,
    options?: RequestInit
  ): Promise<Response>;
  abstract delete(url: string, options?: RequestInit): Promise<Response>;
}
