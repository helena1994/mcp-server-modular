import pino from 'pino';
import { getRequestContext } from '../http/middlewares/request-context';
import { env } from '../config/env';

export const logger = pino({ level: env.LOG_LEVEL });

export function childLogger(bindings: Record<string, unknown>) {
  return logger.child(bindings);
}

export function logWithRequest(msg: string, extra?: Record<string, unknown>) {
  const ctx = getRequestContext();
  logger.info({ reqId: ctx?.requestId, ...extra }, msg);
}
