import React from 'react'
import styled from '@emotion/styled'
import { device } from '../../styles/utils'
import { TitleLabelContainer, TitleLabel } from '../../components/common/titles'
import ItemPreview from './ItemPreview'

const LastItems = ({ items }) => {
  return (
    <>
      <TitleLabelContainer>
        <TitleLabel>Last items added</TitleLabel>
      </TitleLabelContainer>
      {items.length === 0 ? (
        <LastItemsEmptyMessage>Sorry, nothing to show yet</LastItemsEmptyMessage>
      ) : (
        <LastItemsContainer>
          {items.map((item) => (
            <ItemPreview item={item.attributes} key={item.id} id={item.id} />
          ))}
        </LastItemsContainer>
      )}
    </>
  )
}

export default LastItems

export const LastItemsEmptyMessage = styled.h4`
  text-align: center;
  margin-block-end: 2rem;
  text-transform: capitalize;
`
const LastItemsContainer = styled.div`
  width: 90vw;
  height: 15rem;
  overflow-y: hidden;
  overflow-x: auto;
  white-space: nowrap;
  margin: 0 auto;
  padding-block-end: 1rem;

  ${device.lg`
    height: auto;
    display: flex;
    justify-content: center;
    align-items: center;
  `}
`
