import React, { useState, useEffect } from 'react'
import styled from '@emotion/styled'
import { parseCookies } from '../../helpers'
import ItemPreview from '../../components/items/ItemPreview'
import Layout from '../../components/layouts'
import { device } from '../../styles/utils'
import { TitleLabelContainer, TitleLabel } from '../../components/common/titles'
import { LastItemsEmptyMessage } from '../../components/items/LastItems'
import { API_URL } from '../../config'
import Pagination from '../../components/common/pagination'

export default function All({ items, page, total, pages }) {
  return (
    <Layout title="| All items">
      <TitleLabelContainer>
        <TitleLabel>
          All items <span>({total})</span>
        </TitleLabel>
      </TitleLabelContainer>
      {items.length === 0 ? (
        <LastItemsEmptyMessage>Sorry, nothing to show yet</LastItemsEmptyMessage>
      ) : (
        <>
          <ItemsContainer>
            {items.map((item) => (
              <ItemPreview item={item.attributes} key={item.id} id={item.id} />
            ))}
          </ItemsContainer>
          <Pagination
            page={page}
            total={total}
            backUrl={`/items/all?page=${page - 1}`}
            nextUrl={`/items/all?page=${page + 1}`}
          />
          <TitleLabelContainer>
            <TitleLabel>
              <span>{page}</span> / <span>{pages}</span>
            </TitleLabel>
          </TitleLabelContainer>
        </>
      )}
    </Layout>
  )
}

export const ItemsContainer = styled.div`
  width: 90%;
  display: grid;
  grid-template-columns: repeat(1, 1fr);
  place-content: center;
  place-items: center;
  margin: auto;

  ${device.xs`
    grid-template-columns: repeat(2, 1fr);
  `}

  ${device.sm`
    grid-template-columns: repeat(3, 1fr);
  `}

  ${device.md`
    width: 70%;
    grid-template-columns: repeat(4, 1fr);
  `}
  
  ${device.lg`
    width: 50%;
    grid-template-columns: repeat(5, 1fr);
  `}
`

export async function getServerSideProps({ query: { page }, req }) {
  const { token } = parseCookies(req)

  if (!token) {
    return {
      redirect: {
        destination: '/auth/login',
        permanent: false,
      },
    }
  }

  const res = await fetch(`${API_URL}/items?asc&pagination[page]=${page}&populate=*`, {
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

  if (!data) {
    return {
      redirect: {
        destination: '/',
        permanent: false,
      },
    }
  }

  const items = data.filter((item) => userData.items.some((el) => el.id === item.id))

  return {
    props: {
      items,
      page: +page,
      total: userData.items.length,
      data,
      pages: meta.pagination.pageCount,
    },
  }
}
