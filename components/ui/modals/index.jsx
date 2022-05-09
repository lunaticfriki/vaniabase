import { useState, useEffect } from 'react'
import { createPortal } from 'react-dom'
import styled from '@emotion/styled'
import { CloseIcon } from '../../common/icons'
import { MenuButton } from '../../common/menuButton'
import { device } from '../../../styles/utils'

const Modal = ({ show, onClose, children, title }) => {
  const [isBrowser, setIsBrowser] = useState(false)

  useEffect(() => {
    setIsBrowser(true)
  }, [])

  const modalContent = show ? (
    <ModalStyled>
      <ModalHeader>
        {title && <ModalTitle>{title}</ModalTitle>}
        <MenuButton onClick={onClose}>
          <CloseIcon />
        </MenuButton>
      </ModalHeader>
      <ModalBody>{children}</ModalBody>
    </ModalStyled>
  ) : null

  if (isBrowser) {
    return createPortal(modalContent, document.getElementById('modal-root'))
  } else {
    return null
  }
}

export default Modal

const ModalStyled = styled.div`
  width: 100%;
  min-height: 100%;
  position: fixed;
  top: 0;
  right: 0;
  display: grid;
  grid-template-rows: 4rem 1fr;
  background-color: var(--dark_blue);
  color: var(--secondary_white);
  border: 1px solid var(--pink);
  border-radius: 5px;
  z-index: 10;

  ${device.lg`
    width: 40%;
    min-height: auto;
    margin: auto;
    top: 20%;
    left: 50%;
    transform: translate(-50%, 0);
    padding: 1rem;
  `}
`
const ModalHeader = styled.header`
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
`
const ModalBody = styled.section`
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding: 1rem;
`
const ModalTitle = styled.h2``
