import pg from 'pg'
import { env as privateEnv } from '$env/dynamic/private'

import { once } from '$lib/utils/once.js'

const getPgPool = once(() => {
  const databaseUrl = privateEnv.DATABASE_URL

  const pool = new pg.Pool({
    connectionString: databaseUrl,
  })

  pool.on('error', (error) => {
    /*
     * This handler is required so that connection errors don't crash the (via
     * `unhandledError`).
     */
    console.log('PostgreSQL pool error', error)
  })

  return pool
})

const getDb = once(() => {
  const pool = getPgPool()
  return pool.connect()
})

export { getDb }
