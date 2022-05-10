import styled from '@emotion/styled'
import { device } from '../../styles/utils'

export const TitleLabelContainer = styled.div`
  height: 3rem;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  margin: 1rem;

  h4 {
    font-weight: 100;
  }

  ${device.sm`
    justify-content: center;
  `}
`
export const TitleLabel = styled.h4`
  font-weight: 100;
  text-transform: capitalize;

  span {
    color: var(--yellow);
  }
`
