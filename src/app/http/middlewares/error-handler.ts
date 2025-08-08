import { FastifyError, FastifyReply, FastifyRequest } from 'fastify';
import { DomainError } from '../../../domain/shared/errors';

export function errorHandler(error: FastifyError | DomainError, _request: FastifyRequest, reply: FastifyReply) {
  if (error instanceof DomainError) {
    return reply.status(error.httpStatus).send({
      error: error.name,
      message: error.message,
      details: error.details,
    });
  }
  const statusCode = (error as any).statusCode || 500;
  reply.status(statusCode).send({
    error: error.name || 'InternalError',
    message: error.message,
  });
}
