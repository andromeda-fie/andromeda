defmodule Andromeda.Astrolog do  
  @lowest 100_000
  @highest 999_999

  def generate_certification do
    :crypto.strong_rand_bytes(4)
    |> Stream.unfold(fn _ ->
      random_cert = :rand.uniform(@highest - @lowest + 1) + @lowest
      cert_with_check_digit = add_check_digit(random_cert)
      {cert_with_check_digit, :crypto.strong_rand_bytes(4)}
    end)
    |> Stream.filter(&(validate_certification(&1) == :ok))
    |> Enum.take(1)
    |> List.first()
  end

  defp add_check_digit(partial_cert) do
    digits = Integer.digits(partial_cert)
    check_digit = calculate_check_digit(digits)
    Integer.to_string(partial_cert) <> "-" <> Integer.to_string(check_digit)
  end

  defp calculate_check_digit(digits) do
    sum =
      digits
      |> Enum.zip(2..7)
      |> Enum.map(fn {digit, weight} -> digit * weight end)
      |> Enum.sum()

    mod_result = rem(sum, 11)
    check_digit = 11 - mod_result
    if check_digit >= 10, do: 0, else: check_digit
  end

  def validate_certification(cert) do
    digits =
      cert
      |> String.replace(~r/\D/, "")
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)

    sum =
      digits
      |> Enum.zip(2..7)
      |> Enum.map(fn {digit, weight} -> digit * weight end)
      |> Enum.sum()

    mod_result = rem(sum, 11)
    check_digit = if 11 - mod_result >= 10, do: 0, else: 11 - mod_result

    if check_digit == List.last(digits) do
      :ok
    else
      {:error, {:certificacao, :invalid}}
    end
  end
end
