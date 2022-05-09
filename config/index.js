export const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:1337/api'
export const NEXT_URL = process.env.NEXT_PUBLIC_FRONTEND_URL || 'http://localhost:3000'

// TODO: let user dynamically change per_page
export const PER_PAGE = 25

export const itemsPerPage = (data, page) => {
  let items
  if (page === 1) {
    items = data.filter((item, idx) => idx < PER_PAGE)
  } else {
    items = data.filter(
      (item, idx) => idx >= (page - 1) * PER_PAGE && idx < (page - 1) * PER_PAGE + PER_PAGE
    )
  }
  return items
}
