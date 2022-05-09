import styled from '@emotion/styled'
import { transition } from '../../styles/utils'

export const BackButton = styled.button`
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: transparent;
  color: var(--secondary_white);
  border: 1px solid transparent;
  border-radius: 5px;
  padding: 0.5rem;
  margin: 0.25rem;
  font-size: 1.2rem;
  font-family: Tomorrow, sans-serif;

  svg {
    ${transition}
    color: var(--secondary_white);
  }

  &:hover {
    cursor: pointer;
    color: var(--pink);

    svg {
      color: var(--pink);
    }
  }
`
