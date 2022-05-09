import Link from 'next/link'
import { ArrowBackIcon, ArrowNextIcon } from '../common/icons'

export const ArrowBack = ({ url }) => {
  return (
    <Link href={url}>
      <div>
        <ArrowBackIcon />
      </div>
    </Link>
  )
}

export const ArrowNext = ({ page, url }) => {
  return (
    <Link href={url}>
      <div>
        <ArrowNextIcon />
      </div>
    </Link>
  )
}
