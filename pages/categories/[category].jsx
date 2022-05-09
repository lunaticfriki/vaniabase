import { useRouter } from 'next/router'
import styled from '@emotion/styled'
import { API_URL } from '../../config'
import { device } from '../../styles/utils'
import Layout from '../../components/layouts'
import ItemPreview from '../../components/items/ItemPreview'
import { TitleLabelContainer, TitleLabel } from '../../components/common/titles'
import Pagination from '../../components/common/pagination'
import { parseCookies } from '../../helpers'

const CategoryPage = ({ data, category, page, total }) => {
  return (
    <Layout title={`| Category: ${category}`}>
      <TitleLabelContainer>
        <TitleLabel>
          {category} <span>({total})</span>
        </TitleLabel>
      </TitleLabelContainer>
      <CategoryContainer>
        <CategoryList>
          {data.map((el) => (
            <ItemPreview item={el.attributes} key={el.id} id={el.id} />
          ))}
        </CategoryList>
        {data.length === 0 ? (
          <SearchMessage> Sorry, nothing found</SearchMessage>
        ) : (
          <Pagination
            page={page}
            total={total}
            backUrl={`/categories/${category}?page=${page - 1}`}
            nextUrl={`/categories/${category}?page=${page + 1}`}
          />
        )}
      </CategoryContainer>
    </Layout>
  )
}
export default CategoryPage

const CategoryContainer = styled.div`
  width: 100%;
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  flex-direction: column;
  margin: auto;

  ${device.xl`
    width: 70%;
  `}
`
const CategoryList = styled.div`
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  margin: auto;
`
const SearchMessage = styled.p`
  text-align: center;
`

export async function getServerSideProps({ query: { category, page }, req }) {
  const { token } = parseCookies(req)

  if (!token) {
    return {
      redirect: {
        destination: '/auth/login',
        permanent: false,
      },
    }
  }

  const res = await fetch(
    `${API_URL}/items?filters[category]=${category}&pagination[page]=${page}&populate=*`,
    {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    }
  )
  const { data, meta } = await res.json()

  const user = await fetch(`${API_URL}/users/me`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  })

  const userData = await user.json()

  if (!data) {
    return {
      redirect: {
        destination: '/',
        permanent: false,
      },
    }
  }

  const categoryItems = data.filter((item) => userData.items.some((el) => el.id === item.id))

  return {
    props: {
      data: categoryItems,
      category,
      page: +page,
      total: userData.items.length,
    },
  }
}
