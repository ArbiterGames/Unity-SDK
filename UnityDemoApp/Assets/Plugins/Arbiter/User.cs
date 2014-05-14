#pragma warning disable 661, 659

using System;


namespace ArbiterInternal {
    
    
    public class User
    {
        public string Id;
        public string Name;


        public override string ToString() {
            return "[User id:"+Id+", name:"+Name+"]";
        }


        public override bool Equals( object o ) {
            User that = o == null? null : o as User;
            return that != null && this.Id == that.Id;
        }
        public static bool operator == ( User a, User b ) {
            if( object.ReferenceEquals( null, a ))
                return object.ReferenceEquals( null, b );
            return a.Equals( b );
        }
        public static bool operator != ( User a, User b ) {
            if( object.ReferenceEquals( null, a ))
                return !object.ReferenceEquals( null, b );
            return !a.Equals( b );
        }

    }
    
    
} // namespace ArbiterInternal
