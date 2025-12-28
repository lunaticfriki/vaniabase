import { injectable } from 'inversify';
import { ErrorManager } from '../../domain/services/errorManager.service';

@injectable()
export class ConsoleErrorManager implements ErrorManager {
  handleError(error: unknown): void {
    console.error('Error occurred:', error);
  }
}
