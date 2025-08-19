import { Hono } from "hono";\nimport { cors } from "hono/cors";\nconst app = new Hono();\napp.use("*", cors());\napp.get("/healthz", c => c.json({ ok: true, ts: Date.now() }));\nexport default app;\n
