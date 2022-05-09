import { useState, useEffect, createContext } from 'react'
import { useRouter } from 'next/router'
import { NEXT_URL } from '../config'

export const AuthContext = createContext(null)

export const AuthProvider = ({ children }) => {
  const router = useRouter()
  const [user, setUser] = useState({ name: 'Rodia' })
  const [error, setError] = useState(null)

  useEffect(() => {
    checkUserLoggedIn()
  }, [])

  const registerUser = async (user) => {
    const res = await fetch(`${NEXT_URL}/api/register`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(user),
    })
    const data = await res.json()

    if (res.ok) {
      setUser(data.user)
      router.push('/')
    } else {
      setError(data.message.error.message)
    }
  }

  const loginUser = async ({ email: identifier, password }) => {
    const res = await fetch(`${NEXT_URL}/api/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        identifier,
        password,
      }),
    })
    const data = await res.json()

    if (res.ok) {
      setUser(data.user)
      router.push('/')
    } else {
      setError(data.message.error.message)
    }
  }

  const logout = async () => {
    const res = await fetch(`${NEXT_URL}/api/logout`, {
      method: 'POST',
    })
    if (res.ok) {
      setUser(null)
      router.push('/auth/login')
    }
  }

  const checkUserLoggedIn = async () => {
    const res = await fetch(`${NEXT_URL}/api/user`)
    const data = await res.json()
    if (res.ok) {
      setUser(data.user)
    } else {
      setUser(null)
    }
  }

  return (
    <AuthContext.Provider value={{ user, error, registerUser, loginUser, logout }}>
      {children}
    </AuthContext.Provider>
  )
}

export default AuthProvider
