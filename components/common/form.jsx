import styled from '@emotion/styled'
import { bggradient, device, transition } from '../../styles/utils'

export const AuthStyled = styled.div`
  width: 100%;
  height: 100%;
  padding: 1rem;
  display: grid;
  place-items: center;
  place-content: center;
`
export const AuthTitle = styled.h1`
  margin-block-end: 1rem;
`
export const Form = styled.form`
  position: relative;
  width: 100%;
  height: 100%;
  padding: 1rem;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
`
export const InputStyled = styled.div`
  ${bggradient};

  width: 350px;
  height: 4rem;
  display: flex;
  align-items: center;
  justify-content: ${({ error }) => (error ? 'flex-start' : 'center')};
  text-align: center;
  border-radius: 5px;
  margin: 0.25rem auto;
`
export const Input = styled.input`
  ${transition};

  font-family: Tomorrow, sans-serif;
  border: none;
  border-radius: 5px;
  color: var(--secondary-white);
  width: ${({ error }) => (error ? '50%' : '98%')};
  height: 90%;
  background-color: var(--dark_blue);
  margin: ${({ error }) => (error ? 'auto 0.25rem' : 'auto')};
  padding: 1rem;
  outline: none;

  &[type='submit'] {
    text-transform: uppercase;
    cursor: pointer;

    &:hover {
      ${bggradient};
    }

    &:disabled {
      cursor: not-allowed;

      &:hover {
        background: var(--dark_blue);
      }
    }
  }
`
export const TextareaStyled = styled(InputStyled)`
  min-height: 12rem;
`

export const Textarea = styled.textarea`
  ${transition};

  font-family: Tomorrow, sans-serif;
  border: none;
  border-radius: 5px;
  color: var(--secondary-white);
  width: ${({ error }) => (error ? '50%' : '98%')};
  height: 97%;
  background-color: var(--dark_blue);
  margin: ${({ error }) => (error ? 'auto 0.25rem' : 'auto')};
  padding: 1rem;
  resize: none;
`
export const Select = styled.select`
  ${transition};

  font-family: Tomorrow, sans-serif;
  border: none;
  border-radius: 5px;
  color: var(--secondary-white);
  width: ${({ error }) => (error ? '50%' : '98%')};
  height: 92%;
  background-color: var(--dark_blue);
  margin: ${({ error }) => (error ? 'auto 0.25rem' : 'auto')};
  padding: 1rem;
  cursor: pointer;
`
export const FormErrorMessage = styled.p`
  color: var('--yellow');
  text-transform: uppercase;
  padding: 0.25rem;
  font-size: 0.7rem;
`
export const InputFile = styled.input`
  ${transition};

  font-family: Tomorrow, sans-serif;
  border: none;
  border-radius: 5px;
  color: var(--secondary-white);
  width: ${({ error }) => (error ? '50%' : '98%')};
  height: 90%;
  background-color: var(--dark_blue);
  margin: ${({ error }) => (error ? 'auto 0.25rem' : 'auto')};
  padding: 1rem;
`
export const SearchInputContainer = styled(InputStyled)`
  position: absolute;
  width: 320px;

  input {
    width: 73%;
  }

  p {
    font-size: 0.9rem;
    padding: 0 1rem;
    cursor: pointer;
  }

  ${device.lg`
    top: 4rem;
  `}
`
