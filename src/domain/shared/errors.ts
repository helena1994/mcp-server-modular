export class DomainError extends Error {
  readonly httpStatus: number;
  readonly details?: unknown;
  constructor(message: string, httpStatus = 400, details?: unknown) {
    super(message);
    this.name = this.constructor.name;
    this.httpStatus = httpStatus;
    this.details = details;
  }
}

export class ValidationError extends DomainError {
  constructor(message: string, details?: unknown) {
    super(message, 422, details);
  }
}

export class AuthError extends DomainError {
  constructor(message = 'Unauthorized') { super(message, 401); }
}
