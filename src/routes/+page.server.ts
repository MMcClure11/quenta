import type { PageServerLoad } from './$types.js'

import { getDb } from '$lib/get-db.js'

const load = (async () => {
  const db = await getDb()

  const result = await db.query(
    `SELECT count(id) AS "userCount" FROM public.user`,
  )
  const { userCount } = result.rows.at(0)

  return {
    userCount,
  }
}) satisfies PageServerLoad

export { load }
