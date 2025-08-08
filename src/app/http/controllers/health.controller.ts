import { FastifyInstance, FastifyReply, FastifyRequest } from 'fastify';
import { env } from '../../config/env';

export function registerHealthController(app: FastifyInstance) {
  app.get('/health', async (_req: FastifyRequest, reply: FastifyReply) => {
    return reply.send({ status: 'ok', service: env.APP_NAME, time: new Date().toISOString() });
  });
  app.get('/version', async (_req, reply) => {
    return reply.send({ version: process.env.npm_package_version });
  });
}
