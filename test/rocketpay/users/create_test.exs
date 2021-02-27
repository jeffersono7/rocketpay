defmodule Rocketpay.Users.CreateTest do
  use Rocketpay.DataCase, async: true

  alias Rocketpay.{Repo, User, Users.Create}
  alias Ecto.Changeset

  describe "call/1" do
    test "when all params are valid, returns an user" do
      params = %{
        name: "Jefferson",
        password: "123456",
        nickname: "Farias",
        email: "jefferson-testador@teste.com",
        age: 29
      }

      {:ok, %User{id: user_id}} = Create.call(params)

      user = Repo.get(User, user_id)

      assert %User{name: "Jefferson", age: 29, id: ^user_id} = user
    end

    test "when there are invalid params, returns an error" do
      params = %{
        name: "Jefferson",
        nickname: "Farias",
        email: "jefferson-testador@teste.com",
        age: 1
      }

      {:error, %Changeset{valid?: false} = changeset} = Create.call(params)

      expected_response = %{
        age: ["must be greater than or equal to 18"],
        password: ["can't be blank"]
      }

      assert expected_response == errors_on(changeset)
    end
  end
end
