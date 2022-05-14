import styled from '@emotion/styled'
import Layout from '../../components/layouts'
import Categories from '../../components/categories'
import { Line } from '../../components/common/line'
import { parseCookies } from '../../helpers'

const CategoriesPage = ({ categories }) => {
  return (
    <Layout title="| Categories">
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

  const categories = ['books', 'videogames', 'music', 'magazines', 'comics', 'video']

  return {
    props: { categories },
  }
}
