defmodule Rocketpay.Users.Create do
  alias Rocketpay.{User, Account, Repo}

  alias Ecto.Multi

  def call(params) do
    Multi.new()
    |> Multi.insert(:create_user, User.changeset(params))
    |> Multi.run(:create_account, &insert_account/2)
    |> Multi.run(:preload_data, &preload_data/2)
    |> run_transaction()
  end

  defp insert_account(repo, %{create_user: user}) do
    user.id
    |> account_changeset()
    |> repo.insert()
  end

  defp account_changeset(user_id) do
    params = %{user_id: user_id, balance: "0.00"}

    Account.changeset(params)
  end

  defp run_transaction(multi) do
    case Repo.transaction(multi) do
      {:error, _operation, reason, _changes} -> {:error, reason}
      {:ok, %{preload_data: user}} -> {:ok, user}
    end
  end

  defp preload_data(repo, %{create_user: user}) do
    {:ok, repo.preload(user, :account)}
  end
end
