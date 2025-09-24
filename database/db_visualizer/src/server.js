import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import swaggerUi from 'swagger-ui-express';
import swaggerJsdoc from 'swagger-jsdoc';
import routes from './routes/index.js';

dotenv.config();

// PUBLIC_INTERFACE
export function createApp() {
  /** Create and configure the Express app.
   * Returns:
   *   Express.Application instance configured with middleware and routes.
   */
  const app = express();

  // Security headers; allow embedding if needed but keep safe defaults.
  app.use(helmet({
    crossOriginEmbedderPolicy: false,
  }));

  // Enable CORS for all origins by default; can be restricted via env.
  const corsOrigin = process.env.CORS_ORIGIN || '*';
  app.use(cors({ origin: corsOrigin }));

  // Logging
  app.use(morgan('dev'));

  // JSON parsing
  app.use(express.json({ limit: '2mb' }));

  // Health check
  app.get('/health', (req, res) => {
    res.json({ status: 'ok' });
  });

  // API routes
  app.use('/api', routes);

  // Swagger/OpenAPI basic setup
  const swaggerDefinition = {
    openapi: '3.0.0',
    info: {
      title: 'DB Visualizer API',
      version: '1.0.0',
      description: 'REST API for database visualization and management.',
    },
    servers: [
      { url: `http://localhost:${process.env.PORT || 3000}` }
    ],
    tags: [
      { name: 'Health', description: 'Service health endpoints' },
      { name: 'Database', description: 'Database visualization endpoints' }
    ],
  };

  const options = {
    definition: swaggerDefinition,
    apis: ['./src/routes/*.js'],
  };

  const swaggerSpec = swaggerJsdoc(options);
  app.use('/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

  return app;
}

// PUBLIC_INTERFACE
export function startServer() {
  /** Start the HTTP server using PORT env or default 3000.
   * Env:
   *   PORT: Port number for the HTTP server.
   * Returns:
   *   The created http.Server instance.
   */
  const app = createApp();
  const port = process.env.PORT || 3000;
  return app.listen(port, () => {
    // eslint-disable-next-line no-console
    console.log(`DB Visualizer backend listening on port ${port}`);
  });
}

if (process.argv[1] === new URL(import.meta.url).pathname) {
  startServer();
}
