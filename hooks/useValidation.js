import { useState, useEffect } from 'react'

const useValidation = (initialState, validate, fn) => {
  const [values, setValues] = useState(initialState)
  const [errors, setErrors] = useState({})
  const [submitForm, setSubmitForm] = useState(false)

  useEffect(() => {
    if (submitForm) {
      const noErrors = Object.keys(errors).length === 0

      if (noErrors) {
        fn()
      }
      setSubmitForm(false)
    }
    // eslint-disable-next-line
  }, [errors])

  const handleChange = (e) => {
    setValues({
      ...values,
      [e.target.name]: e.target.value,
    })
  }

  const handleSubmit = (e) => {
    e.preventDefault()

    const validationErrors = validate(values)
    setErrors(validationErrors)
    setSubmitForm(true)
  }

  return { values, setValues, errors, handleChange, handleSubmit }
}

export default useValidation
