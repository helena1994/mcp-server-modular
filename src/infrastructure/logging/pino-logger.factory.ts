import pino from 'pino';
import { env } from '../../app/config/env';
import { getRequestContext } from '../../app/http/middlewares/request-context';

export function buildLogger() {
  return pino({
    level: env.LOG_LEVEL,
    transport: env.NODE_ENV === 'development' ? { target: 'pino-pretty', options: { colorize: true } } : undefined,
    serializers: {
      reqId() {
        return getRequestContext()?.requestId;
      },
    },
  });
}
