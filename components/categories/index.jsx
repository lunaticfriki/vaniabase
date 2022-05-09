import React from 'react'
import Link from 'next/link'
import styled from '@emotion/styled'
import { TitleLabelContainer, TitleLabel } from '../common/titles'

const Categories = ({ categories }) => {
  return (
    <>
      <TitleLabelContainer>
        <TitleLabel>Categories</TitleLabel>
      </TitleLabelContainer>
      <CategoryList>
        {categories.map((category, idx) => (
          <Link href={`categories/${category}?page=1`} key={idx}>
            <CategoryElement>{category}</CategoryElement>
          </Link>
        ))}
      </CategoryList>
    </>
  )
}

export default Categories

const CategoryList = styled.div`
  min-height: 7rem;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-wrap: wrap;
  padding: 2rem 0;
`
const CategoryElement = styled.p`
  padding: 1rem;
  cursor: pointer;
  text-transform: uppercase;

  &:hover {
    color: var(--yellow);
  }
`
