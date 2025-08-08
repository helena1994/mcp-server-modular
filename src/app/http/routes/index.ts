import { FastifyInstance } from 'fastify';
import { registerHealthController } from '../controllers/health.controller';

export function registerRoutes(app: FastifyInstance) {
  registerHealthController(app);
  // TODO: register auth, user, role routes
}
