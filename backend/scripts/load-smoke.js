/**
 * k6 smoke load test for NFR-B001 read latency (staging/local).
 *
 * Usage:
 *   k6 run -e BASE_URL=https://localhost:7xxx -e AUTH_TOKEN=<jwt> load-smoke.js
 *
 * Targets (MVP): p95 < 300ms for GET /health and GET /events (excluding cold start).
 */
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend } from 'k6/metrics';

const healthDuration = new Trend('health_duration', true);
const eventsDuration = new Trend('events_duration', true);

export const options = {
  vus: 5,
  duration: '30s',
  thresholds: {
    health_duration: ['p(95)<300'],
    events_duration: ['p(95)<300'],
    http_req_failed: ['rate<0.05'],
  },
};

const baseUrl = __ENV.BASE_URL || 'https://localhost:5001';
const token = __ENV.AUTH_TOKEN || '';

export default function () {
  const headers = token ? { Authorization: `Bearer ${token}` } : {};

  const health = http.get(`${baseUrl}/health`);
  healthDuration.add(health.timings.duration);
  check(health, { 'health 200': (r) => r.status === 200 });

  const events = http.get(`${baseUrl}/events?limit=20`, { headers });
  eventsDuration.add(events.timings.duration);
  check(events, { 'events 200': (r) => r.status === 200 });

  sleep(1);
}
