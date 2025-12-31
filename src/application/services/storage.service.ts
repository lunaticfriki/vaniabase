export abstract class StorageService {
  abstract upload(file: File, path: string): Promise<string>;
}
