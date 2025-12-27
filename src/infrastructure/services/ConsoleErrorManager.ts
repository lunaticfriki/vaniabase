import { injectable } from 'inversify';
import { ErrorManager } from '../../domain/services/ErrorManager';

@injectable()
export class ConsoleErrorManager implements ErrorManager {
    handleError(error: unknown): void {
        console.error('Error occurred:', error);
    }
}
