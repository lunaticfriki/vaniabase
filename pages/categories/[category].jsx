import styled from '@emotion/styled'
import { API_URL } from '../../config'
import Layout from '../../components/layouts'
import ItemPreview from '../../components/items/ItemPreview'
import { TitleLabelContainer, TitleLabel } from '../../components/common/titles'
import Pagination from '../../components/common/pagination'
import { parseCookies } from '../../helpers'
import React from 'react'
import { ItemsContainer } from '../items/all'

const CategoryPage = ({ data, category, page, total, pages }) => {
  return (
    <Layout title={`| Category: ${category}`}>
      <TitleLabelContainer>
        <TitleLabel>
          {category} <span>({total})</span>
        </TitleLabel>
      </TitleLabelContainer>
      <ItemsContainer>
        {data.map((el) => (
          <ItemPreview item={el.attributes} key={el.id} id={el.id} />
        ))}
      </ItemsContainer>
      {data.length === 0 ? (
        <SearchMessage> Sorry, nothing found</SearchMessage>
      ) : (
        <CategoryListFooter>
          <Pagination
            page={page}
            total={total}
            backUrl={`/categories/${category}?page=${page - 1}`}
            nextUrl={`/categories/${category}?page=${page + 1}`}
          />
          <TitleLabelContainer>
            <TitleLabel>
              <span>{page}</span> / <span>{pages}</span>
            </TitleLabel>
          </TitleLabelContainer>
        </CategoryListFooter>
      )}
    </Layout>
  )
}
export default CategoryPage

const SearchMessage = styled.p`
  text-align: center;
`

export const CategoryListFooter = styled.div`
  width: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
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
      total: categoryItems.length,
      pages: meta.pagination.pageCount,
    },
  }
}
