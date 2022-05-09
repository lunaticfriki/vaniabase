import Link from 'next/link'
import PropTypes from 'prop-types'
import styled from '@emotion/styled'
import { device, transition } from '../../styles/utils'

const ItemPreview = ({ item, id }) => {
  return (
    <ItemPreviewStyled image={item.image.data?.attributes.url}>
      <Link href={`/items/${item.slug}`} passHref>
        <ItemTextContainer>
          <ItemText>{item.title}</ItemText>
        </ItemTextContainer>
      </Link>
    </ItemPreviewStyled>
  )
}

export default ItemPreview

ItemPreview.propTypes = {
  item: PropTypes.object.isRequired
}

const ItemPreviewStyled = styled.article`
  width: 150px;
  height: 200px;
  display: inline-block;
  overflow: hidden;
  margin: 1rem;
  background-image: url(${({ image }) => image ? image : '/images/not_found.png'});
  background-position: center;
  background-size: cover;
  border-radius: 5px;

  ${device.xl`
    width: 200px;
    height: 250px;
    display: flex;
    justify-content: center;
    align-items: flex-end;
  `}
  &:hover {
    cursor: pointer;

    p {
      ${device.lg`
       transform: translateY(0);
    `}
    }
  }
`

const ItemTextContainer = styled.div`
  width: 100%;
  height: 100%;
  display: flex;
  align-items: flex-end;
  justify-content: flex-end;
`
const ItemText = styled.p`
  ${transition}

  width: 100%;
  background-color: var(--yellow);
  border-radius: 0 0 5px 5px;
  color: var(--blur);
  padding: 1rem;
  font-size: 0.8rem;
  text-overflow: ellipsis;
  overflow: hidden;

  ${device.lg`
    transform: translateY(15rem);
    font-size: 0.9rem;
  `}
`
