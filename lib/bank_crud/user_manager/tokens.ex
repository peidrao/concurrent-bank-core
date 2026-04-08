defmodule BankCrud.UserManager.Tokens do
  alias BankCrud.Repo
  alias BankCrud.UserManager.{Guardian, RefreshToken, User}

  import Ecto.Query, only: [from: 2]

  @access_ttl {15, :minute}
  @refresh_ttl_days 7

  def issuer_pair(%User{} = user) do
    with {:ok, access, _} <-
           Guardian.encode_and_sign(user, %{"typ" => "access"}, ttl: @access_ttl),
         {:ok, refresh, claims} <-
           Guardian.encode_and_sign(user, %{"typ" => "refresh"}, ttl: {@refresh_ttl_days, :day}),
         :ok <- persist_refresh(user.id, refresh, claims) do
      {:ok, %{access_token: access, refresh_token: refresh}}
    end
  end

  def rotate_refresh(refresh_token) do
    with {:ok, claims} <- Guardian.decode_and_verify(refresh_token, %{"typ" => "refresh"}),
         :ok <- verify_not_revoked(refresh_token, claims),
         {:ok, user} <- Guardian.resource_from_claims(claims),
         :ok <- revoke_by_jti(claims["jti"]),
         {:ok, pair} <- issuer_pair(user) do
      {:ok, pair}
    end
  end

  def revoke_refresh(refresh_token) do
    with {:ok, claims} <- Guardian.decode_and_verify(refresh_token, %{"typ" => "refresh"}) do
      revoke_by_jti(claims["jti"])
    end
  end

  defp persist_refresh(user_id, raw_token, claims) do
    expires_at = DateTime.from_unix!(claims["exp"], :second)

    %RefreshToken{}
    |> RefreshToken.changeset(%{
      user_id: user_id,
      jti: claims["jti"],
      token_hash: Argon2.hash_pwd_salt(raw_token),
      expires_at: expires_at
    })
    |> Repo.insert()
    |> case do
      {:ok, _} -> :ok
      {:error, _} = err -> err
    end
  end

  defp claims_token_hash(jti) do
    Repo.get_by!(RefreshToken, jti: jti).token_hash
  end

  defp revoke_by_jti(jti) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    from(rt in RefreshToken, where: rt.jti == ^jti)
    |> Repo.update_all(set: [revoked_at: now])

    :ok
  end

  defp verify_not_revoked(raw_token, claims) do
    case Repo.get_by(RefreshToken, jti: claims["jti"]) do
      nil ->
        {:error, :refresh_not_found}

      %{revoked_at: rev} when not is_nil(rev) ->
        {:error, :refresh_revoked}

      %{expires_at: exp} ->
        if DateTime.compare(exp, DateTime.utc_now()) == :gt and
             Argon2.verify_pass(raw_token, claims_token_hash(claims["jti"])) do
          :ok
        else
          {:error, :refresh_invalid}
        end
    end
  end
end
