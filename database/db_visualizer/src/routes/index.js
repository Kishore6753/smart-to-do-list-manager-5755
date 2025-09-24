import { Router } from 'express';

const router = Router();

/**
 * @openapi
 * /api/ping:
 *   get:
 *     summary: Ping endpoint
 *     description: Returns pong to verify the API is reachable.
 *     tags:
 *       - Health
 *     responses:
 *       '200':
 *         description: Pong response
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: pong
 */
router.get('/ping', (req, res) => {
  res.json({ message: 'pong' });
});

/**
 * @openapi
 * /api/databases:
 *   get:
 *     summary: List configured database types
 *     description: Lists database types supported by the service. Placeholder endpoint for future detailed connectivity.
 *     tags:
 *       - Database
 *     responses:
 *       '200':
 *         description: Supported database types
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 supported:
 *                   type: array
 *                   items:
 *                     type: string
 *                   example: [ "postgresql", "mysql", "sqlite", "mongodb" ]
 */
router.get('/databases', (req, res) => {
  res.json({ supported: ['postgresql', 'mysql', 'sqlite', 'mongodb'] });
});

export default router;
