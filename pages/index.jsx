import { API_URL } from '../config'
import { parseCookies } from '../helpers'

import Layout from '../components/layouts'
import LastItems from '../components/items/LastItems'
import Categories from '../components/categories'
import { Line } from '../components/common/line'

export default function Home({ items, categories }) {
  return (
    <Layout title="| Home">
      <Categories categories={categories} />
      <Line />
      <LastItems items={items} />
      <Line />
    </Layout>
  )
}

export async function getServerSideProps({ req }) {
  const { token } = parseCookies(req)

  const categories = ['books', 'videogames', 'music', 'magazines', 'comics']

  const res = await fetch(`${API_URL}/items?sort=createdAt:desc&populate=*`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  })

  const { data } = await res.json()

  const user = await fetch(`${API_URL}/users/me`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  })

  const userData = await user.json()

  if (!token) {
    return {
      redirect: {
        destination: '/auth/login',
        permanent: false,
      },
    }
  }

  const items = data.filter((item) => userData.items.some((el) => el.id === item.id))

  const lastItems = items.filter((el, idx) => idx < 5)

  return {
    props: { items: lastItems, categories },
  }
}
