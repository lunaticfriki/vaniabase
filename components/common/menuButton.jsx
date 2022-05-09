import styled from '@emotion/styled'
import { transition } from '../../styles/utils'

export const MenuButton = styled.button`
  ${transition};

  color: var(--secondary_white);
  background-color: transparent;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
  border-radius: 5px;
  padding: 1rem;
  font-size: 1.5rem;
  font-family: Tomorrow, sans-serif;

  &:hover {
    cursor: pointer;
  }
`
