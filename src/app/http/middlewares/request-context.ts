import { FastifyRequest, FastifyReply } from 'fastify';
import { AsyncLocalStorage } from 'node:async_hooks';

interface RequestContextStore {
  requestId: string;
  startedAt: number;
}

export const requestAsyncStorage = new AsyncLocalStorage<RequestContextStore>();

export function requestContext(req: FastifyRequest, _reply: FastifyReply, done: (err?: Error) => void) {
  const store: RequestContextStore = { requestId: req.id as string, startedAt: Date.now() };
  requestAsyncStorage.run(store, () => done());
}

export function getRequestContext() {
  return requestAsyncStorage.getStore();
}
