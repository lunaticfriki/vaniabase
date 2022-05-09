import React, { useState, useEffect } from 'react'
import styled from '@emotion/styled'
import { parseCookies } from '../../helpers'
import ItemPreview from '../../components/items/ItemPreview'
import Layout from '../../components/layouts'
import { device } from '../../styles/utils'
import { TitleLabelContainer, TitleLabel } from '../../components/common/titles'
import { LastItemsEmptyMessage } from '../../components/items/LastItems'
import { API_URL, itemsPerPage } from '../../config'
import Pagination from '../../components/common/pagination'

export default function All({ items, page, total }) {
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
        </>
      )}
    </Layout>
  )
}

const ItemsContainer = styled.div`
  width: 100%;
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  margin: auto;

  ${device.xl`
    width: 70%;
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

  const res = await fetch(`${API_URL}/items?sort=title:asc&populate=*`, {
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
    props: { items: itemsPerPage(items, +page), page: +page, total: items.length },
  }
}
