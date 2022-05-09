import styled from '@emotion/styled'
import { transition } from '../../styles/utils'
import { ArrowBack, ArrowNext } from './arrows'
import { PER_PAGE } from '../../config'

const Pagination = ({ page, total, backUrl, nextUrl }) => {
  const lastPage = Math.ceil(total / PER_PAGE)

  console.log(`Last page: ${lastPage}, page: ${page}, total: ${total}`)

  return (
    <PaginationContainer>
      {page > 1 && <ArrowBack page={page} url={backUrl} />}
      {page !== lastPage && <ArrowNext page={page} url={nextUrl} />}
    </PaginationContainer>
  )
}

export const PaginationContainer = styled.div`
  width: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  margin: 2rem 0;

  svg:hover {
    ${transition};

    color: var(--pink);
    cursor: pointer;
  }
`
export default Pagination
