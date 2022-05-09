import styled from '@emotion/styled'
import { device } from '../../styles/utils'

export const TitleLabelContainer = styled.div`
  width: 90vw;
  height: 3rem;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  margin: 1rem auto;

  h4 {
    font-weight: 100;
  }

  ${device.lg`
    width: 100%;
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
