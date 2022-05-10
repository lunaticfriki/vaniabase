import React from 'react'
import styled from '@emotion/styled'
import { parseCookies } from '../../helpers'
import qs from 'qs'
import ItemPreview from '../../components/items/ItemPreview'
import Layout from '../../components/layouts'
import { TitleLabelContainer, TitleLabel } from '../../components/common/titles'
import { ItemsContainer } from './all'
import { LastItemsEmptyMessage } from '../../components/items/LastItems'
import { API_URL } from '../../config'
import Pagination from '../../components/common/pagination'
import { CategoryListFooter } from '../categories/[category]'

export default function SearchPage({ items, page, total, term, pages }) {
  return (
    <Layout title={`| Search: ${term}`}>
      <TitleLabelContainer>
        <TitleLabel>
          Search results{' '}
          <span>
            ({term}: {total})
          </span>
        </TitleLabel>
      </TitleLabelContainer>
      {items.length === 0 ? (
        <LastItemsEmptyMessage>Sorry, nothing found</LastItemsEmptyMessage>
      ) : (
        <>
          <ItemsContainer>
            {items.map((item) => (
              <ItemPreview item={item.attributes} key={item.id} id={item.id} />
            ))}
          </ItemsContainer>
          <SearchListFooter>
            <Pagination
              page={page}
              total={total}
              backUrl={`/items/search/?term=${term}&page=${page - 1}`}
              nextUrl={`/items/search/?term=${term}&page=${page + 1}`}
            />
            <TitleLabelContainer>
              <TitleLabel>
                <span>{page}</span> / <span>{pages}</span>
              </TitleLabel>
            </TitleLabelContainer>
          </SearchListFooter>
        </>
      )}
    </Layout>
  )
}

const SearchListFooter = styled(CategoryListFooter)``

export async function getServerSideProps({ query: { term, page }, req }) {
  const { token } = parseCookies(req)

  if (!token) {
    return {
      redirect: {
        destination: '/auth/login',
        permanent: false,
      },
    }
  }

  const query = qs.stringify(
    {
      filters: {
        $or: [
          {
            title: {
              $containsi: term,
            },
          },
          {
            author: {
              $containsi: term,
            },
          },
          {
            publisher: {
              $containsi: term,
            },
          },
          {
            topic: {
              $containsi: term,
            },
          },
          {
            format: {
              $containsi: term,
            },
          },
          {
            tags: {
              $containsi: term,
            },
          },
          {
            language: {
              $containsi: term,
            },
          },
          {
            category: {
              $containsi: term,
            },
          },
          {
            description: {
              $containsi: term,
            },
          },
        ],
      },
    },
    {
      encodeValuesOnly: true,
    }
  )
  const res = await fetch(`${API_URL}/items?${query}&pagination[page]=${page}&populate=*`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  })
  const { data, meta } = await res.json()

  const user = await fetch(`${API_URL}/users/me`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  })

  const userData = await user.json()

  const items = data.filter((item) => userData.items.some((el) => el.id === item.id))

  return {
    props: {
      items,
      page: +page,
      total: meta.pagination.total,
      term,
      pages: meta.pagination.pageCount,
    },
  }
}
