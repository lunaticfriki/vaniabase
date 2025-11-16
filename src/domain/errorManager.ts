export enum ErrorType {
  SERVER = 'SERVER',
  CONNECTION = 'CONNECTION',
  CLIENT = 'CLIENT',
  VALIDATION = 'VALIDATION',
  UNKNOWN = 'UNKNOWN',
}

export interface AppError {
  type: ErrorType;
  message: string;
  originalError?: Error;
  statusCode?: number;
  timestamp: Date;
}

export abstract class ErrorManager {
  abstract handleError(error: Error | AppError): void;
  abstract logError(error: AppError): void;
  abstract getErrorType(error: Error): ErrorType;
  abstract createAppError(
    type: ErrorType,
    message: string,
    originalError?: Error,
    statusCode?: number
  ): AppError;
}
