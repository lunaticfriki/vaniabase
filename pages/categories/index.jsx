import styled from '@emotion/styled'
import Layout from '../../components/layouts'
import Categories from '../../components/categories'
import { Line } from '../../components/common/line'
import { arrayOf } from 'prop-types'
import { API_URL } from '../../config'
import { parseCookies } from '../../helpers'

const CategoriesPage = ({ categories }) => {
  return (
    <Layout>
      <CategoryPageContainer>
        <Categories categories={categories} />
        <Line />
      </CategoryPageContainer>
    </Layout>
  )
}

export default CategoriesPage

const CategoryPageContainer = styled.div`
  width: 90%;
  display: flex;
  flex-direction: column;
  margin: auto;
`

export async function getServerSideProps({ req }) {
  const { token } = parseCookies(req)

  if (!token) {
    return {
      redirect: {
        destination: '/auth/login',
        permanent: false,
      },
    }
  }

  const res = await fetch(`${API_URL}/items`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  })

  const { data } = await res.json()
  const categories = [...new Set(data.map((cat) => cat.attributes.category))]

  return {
    props: { categories },
  }
}
