class TextMessagePolicy < ApplicationPolicy
  def create?
    active_user?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where sender: user
    end
  end
end
