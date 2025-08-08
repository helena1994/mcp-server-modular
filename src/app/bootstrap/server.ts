import fastify from 'fastify';
import cors from '@fastify/cors';
import helmet from '@fastify/helmet';
import { registerRoutes } from '../http/routes';
import { env } from '../config/env';
import { errorHandler } from '../http/middlewares/error-handler';
import { requestContext } from '../http/middlewares/request-context';
import { buildLogger } from '../../infrastructure/logging/pino-logger.factory';

async function buildServer() {
  const app = fastify({ logger: buildLogger() });
  await app.register(cors, { origin: true });
  await app.register(helmet);
  app.addHook('onRequest', requestContext);
  app.setErrorHandler(errorHandler);
  registerRoutes(app);
  return app;
}

(async () => {
  const app = await buildServer();
  try {
    await app.listen({ port: env.PORT, host: '0.0.0.0' });
    app.log.info(`Server started on port ${env.PORT}`);
  } catch (err) {
    app.log.error(err, 'Failed to start server');
    process.exit(1);
  }
})();

export { buildServer };
