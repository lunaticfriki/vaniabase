import { ErrorManager, ErrorType, type AppError } from '../domain/errorManager';

export class ErrorManagerImpl extends ErrorManager {
  handleError(error: Error | AppError): void {
    const appError = this.isAppError(error)
      ? error
      : this.createAppErrorFromError(error);

    this.logError(appError);
    this.notifyUser(appError);
  }

  logError(error: AppError): void {
    const errorInfo = {
      type: error.type,
      message: error.message,
      statusCode: error.statusCode,
      timestamp: error.timestamp,
      stack: error.originalError?.stack,
    };

    if (
      error.type === ErrorType.SERVER ||
      error.type === ErrorType.CONNECTION
    ) {
      console.error('[ErrorManager] Critical Error:', errorInfo);
    } else if (error.type === ErrorType.CLIENT) {
      console.warn('[ErrorManager] Client Error:', errorInfo);
    } else {
      console.log('[ErrorManager] Error:', errorInfo);
    }
  }

  getErrorType(error: Error): ErrorType {
    const message = error.message.toLowerCase();

    if (
      message.includes('network') ||
      message.includes('fetch') ||
      message.includes('connection') ||
      message.includes('timeout') ||
      error.name === 'NetworkError' ||
      error.name === 'AbortError'
    ) {
      return ErrorType.CONNECTION;
    }

    if (
      message.includes('server') ||
      message.includes('500') ||
      message.includes('502') ||
      message.includes('503') ||
      message.includes('504')
    ) {
      return ErrorType.SERVER;
    }

    if (
      message.includes('validation') ||
      message.includes('invalid') ||
      message.includes('required')
    ) {
      return ErrorType.VALIDATION;
    }

    if (
      message.includes('unauthorized') ||
      message.includes('forbidden') ||
      message.includes('not found') ||
      message.includes('400') ||
      message.includes('401') ||
      message.includes('403') ||
      message.includes('404')
    ) {
      return ErrorType.CLIENT;
    }

    return ErrorType.UNKNOWN;
  }

  createAppError(
    type: ErrorType,
    message: string,
    originalError?: Error,
    statusCode?: number
  ): AppError {
    return {
      type,
      message,
      originalError,
      statusCode,
      timestamp: new Date(),
    };
  }

  private isAppError(error: Error | AppError): error is AppError {
    return 'type' in error && 'timestamp' in error;
  }

  private createAppErrorFromError(error: Error): AppError {
    const type = this.getErrorType(error);
    const statusCode = this.extractStatusCode(error);

    return this.createAppError(type, error.message, error, statusCode);
  }

  private extractStatusCode(error: Error): number | undefined {
    const statusMatch = error.message.match(/\b(4\d{2}|5\d{2})\b/);
    if (statusMatch) {
      return parseInt(statusMatch[1], 10);
    }

    if ('status' in error && typeof error.status === 'number') {
      return error.status;
    }

    return undefined;
  }

  private notifyUser(error: AppError): void {
    const userMessage = this.getUserFriendlyMessage(error);

    if (error.type === ErrorType.SERVER) {
      console.error('User notification:', userMessage);
    } else if (error.type === ErrorType.CONNECTION) {
      console.error('User notification:', userMessage);
    }
  }

  private getUserFriendlyMessage(error: AppError): string {
    switch (error.type) {
      case ErrorType.SERVER:
        return 'Server error occurred. Please try again later.';
      case ErrorType.CONNECTION:
        return 'Connection error. Please check your internet connection.';
      case ErrorType.CLIENT:
        return error.message || 'Invalid request. Please check your input.';
      case ErrorType.VALIDATION:
        return error.message || 'Validation error. Please check your input.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
